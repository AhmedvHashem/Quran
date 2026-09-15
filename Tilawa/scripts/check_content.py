"""Check the actual bundled bytes and every generated verse; run from any directory."""
import hashlib
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
local = root / "shared/src/commonMain/kotlin/com/hashem/tilawa/data/local"
resource = root / "shared/src/commonMain/resources/quran_text.json"
manifest = (local / "LocalQuranTextSource.kt").read_text()
expected = re.search(r'checksumSha256 = "([a-f0-9]{64})"', manifest)[1]
assert hashlib.sha256(resource.read_bytes()).hexdigest() == expected, "Bundled checksum changed"
payload = json.loads(resource.read_text())
code = (local / "QuranTextData.kt").read_text()
assert [c["id"] for c in payload["chapters"]] == list(range(1, 115))
assert set(payload["surahs"]) == {str(i) for i in range(1, 115)}
assert sum(len(v) for v in payload["surahs"].values()) == 6236
for chapter in payload["chapters"]:
    number = chapter["id"]
    verses = payload["surahs"][str(number)]
    assert [v["number"] for v in verses] == list(range(1, chapter["versesCount"] + 1))
    body = re.search(rf'private fun surah{number}\(\).*?listOf\((.*?)\n    \)', code, re.S)[1]
    generated = [{"number": int(n), "text": json.loads(text)} for n, text in
                 re.findall(r'Verse\((\d+), ("(?:[^"\\]|\\.)*")\)', body)]
    assert generated == verses, f"Compiled text differs in surah {number}"
    assert f"{number} -> surah{number}()" in code
    metadata = re.search(rf'Chapter\({number}, (.*)\),', code)[1]
    fields = re.findall(r'"(?:[^"\\]|\\.)*"', metadata)
    assert [json.loads(v) for v in fields] == [chapter[k] for k in ("name", "translatedName", "arabicName")]
    assert metadata.endswith(f'{chapter["versesCount"]}, RevelationPlace.{chapter["revelationPlace"]}')
print("Content integrity passed: pinned JSON, 114 chapters, 6,236 identical compiled verses.")

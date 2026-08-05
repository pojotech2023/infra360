import os
import json
import glob

history_dir = r"C:\Users\pojot\AppData\Roaming\Code\User\History"
files_to_find = [
    "api_data.dart",
    "material_request_list_screen.dart",
    "site_payment_history_controller.dart",
    "site_payment_history_screen.dart",
    "subcontractor_sitewise_controller.dart",
    "subcontractor_sitewise_screen.dart",
    "my_subcontractor_list_model.dart"
]

results = {}

for root, _, files in os.walk(history_dir):
    if "entries.json" in files:
        entries_path = os.path.join(root, "entries.json")
        try:
            with open(entries_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                resource = data.get("resource", "")
                if "Pojo" in resource and "Infra360" in resource:
                    for target in files_to_find:
                        if resource.endswith(target):
                            results[target] = entries_path
                            print(f"Found {target} at {entries_path}")
        except Exception as e:
            pass

with open("history_locations.json", "w", encoding="utf-8") as f:
    json.dump(results, f, indent=4)

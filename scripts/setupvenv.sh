echo 'Creating Python virtual environment ".venv" in root'
python3.10 -m venv .venv

echo 'Installing dependencies from "requirements.txt" into virtual environment'
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install -r requirements-dev.txt

UV ?= uv
MAKEFLAGS += --no-print-directory
export PYTHONUTF8 := 1

PACKAGE := random_names
PYTHON_TARGETS := random_names test

.PHONY: \
	sync \
	format format-check \
	lint lint-check \
	dead-code \
	test test-ci tox \
	venv315 venv315-clean test315 check315 \
	typecheck \
	security \
	version-check dev-status \
	check check-ci \
	publish-check publish \
	dont-be-lazy pydoc-docs \
	help

help:
	@echo "Targets:"
	@echo "  sync            Install / refresh dependencies"
	@echo ""
	@echo "  format          Auto-format (black + isort)"
	@echo "  format-check    Check formatting without changes"
	@echo "  lint            pylint"
	@echo "  lint-check      pylint (read-only alias)"
	@echo ""
	@echo "  test            Run pytest suite with coverage"
	@echo "  test-ci         Run pytest -n auto (parallel, for CI)"
	@echo "  tox             Run tests across python versions via tox"
	@echo ""
	@echo "  typecheck       Run mypy"
	@echo "  security        Run bandit"
	@echo "  dead-code       Run vulture (advisory)"
	@echo ""
	@echo "  version-check   Verify version consistency (jiggle_version)"
	@echo "  dev-status      Verify Development Status classifier"
	@echo ""
	@echo "  check           Full local quality gate"
	@echo "  check-ci        CI quality gate"
	@echo "  publish-check   Build wheel and list dist/ contents"
	@echo "  publish         Publish via uv"

sync:
	@$(UV) sync --all-extras

# ── Formatting ────────────────────────────────────────────────────────────────

format:
	@$(UV) run isort $(PYTHON_TARGETS)
	@$(UV) run black $(PYTHON_TARGETS)

format-check:
	@$(UV) run isort --check-only $(PYTHON_TARGETS)
	@$(UV) run black --check $(PYTHON_TARGETS)

# ── Linting ───────────────────────────────────────────────────────────────────

lint lint-check:
	@$(UV) run pylint --score=n --reports=n $(PACKAGE)

# ── Dead code (advisory) ──────────────────────────────────────────────────────

dead-code:
	@$(UV) run vulture $(PACKAGE) --min-confidence 80 || true

# ── Tests ─────────────────────────────────────────────────────────────────────

test:
	@$(UV) run pytest -q \
		--cov=$(PACKAGE) \
		--cov-report=html \
		--junitxml=junit.xml \
		--timeout=60 \
		test/

test-ci:
	@$(UV) run pytest -q -n auto --dist=loadfile \
		--cov=$(PACKAGE) \
		--cov-report=xml \
		--junitxml=junit.xml \
		--timeout=60 \
		test/

tox:
	@$(UV) run tox

# ── Python 3.15 trial run ─────────────────────────────────────────────────────
# Uses a dedicated venv so the normal .venv is never touched.

PY315 := 3.15.0rc2
VENV315 := .venv315rc2
PY315_EXE := $(VENV315)/Scripts/python.exe

venv315:
	@echo "Creating Python $(PY315) trial venv at $(VENV315)"
	@test -x $(PY315_EXE) || uv venv $(VENV315) --python $(PY315)
	uv pip install -e . pytest pytest-cov pytest-timeout pytest-mock --python $(PY315_EXE)

venv315-clean:
	@echo "Recreating Python $(PY315) trial venv from scratch"
	uv venv $(VENV315) --python $(PY315) --clear
	@$(MAKE) venv315

test315: venv315
	@echo "Running unit tests on Python $(PY315)"
	$(PY315_EXE) -m pytest test -q --timeout=60 -p no:randomly -p no:sugar

check315: test315
	@echo "Python $(PY315) checks passed."

# ── Type checking ─────────────────────────────────────────────────────────────

typecheck:
	@$(UV) run mypy $(PACKAGE)

# ── Security ──────────────────────────────────────────────────────────────────

security:
	@$(UV) run bandit -q -r $(PACKAGE)

# ── Metadata / version ───────────────────────────────────────────────────────

version-check:
	@$(UV) run jiggle_version check

dev-status:
	@$(UV) run troml-dev-status validate .

# ── Release ───────────────────────────────────────────────────────────────────

publish-check:
	@$(UV) build
	@ls -lh dist/

publish:
	@$(UV) publish

# ── Gates ─────────────────────────────────────────────────────────────────────

check: lint security test typecheck version-check
	@echo "All checks passed."

check-ci: lint security test-ci typecheck version-check
	@echo "CI checks passed."

# ── Dogfooding ────────────────────────────────────────────────────────────────

dont-be-lazy:
	@$(UV) run dont_be_lazy --root . --no-color summary
	@$(UV) run dont_be_lazy --root . --no-color scan $(PACKAGE) --no-config-suppressions || true

pydoc-docs:
	@$(UV) run pydoc_fork $(PACKAGE) -o ./pydoc/

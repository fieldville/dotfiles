.DEFAULT_GOAL := help
EDITOR ?= vim

# 変数は make 起動時に 1 回だけ評価する(:= と $(shell))。
# `*.md` だと README.md などを拾うので memo-*.md に限定する。
# アーカイブ済み(archives/YYYY/MM/)も含めてファイル名(日付)で並べ、最新を選ぶ。
LATEST_FILE   := $(shell ls -1 memo-*.md archives/*/*/memo-*.md 2>/dev/null | awk -F/ '{print $$NF, $$0}' | sort | tail -n 1 | cut -d' ' -f2)
TODAY_FILE    := memo-$(shell date +%Y%m%d).md
# GNU Make 4.2 以前(macOS 標準の 3.81 など)は $(shell) 内の `#` をコメント開始と解釈するので変数経由で渡す。
HASH          := \#
# 曜日(%a)はロケール依存なので LC_ALL=C で英語表記(Thu など)に固定する。
TODAY_HEADER  := $(shell LC_ALL=C date '+$(HASH) %Y/%m/%d(%a)')
UNTRACKED_MD  := $(filter-out $(TODAY_FILE),$(shell git ls-files --others --exclude-standard -- 'memo-*.md'))
GITLEAKS_OPTS := --redact --no-banner --config .gitleaks.toml

# アーカイブ対象: 先週以前(今週より前)の日付のファイル。週は月曜始まり。
# LAST_WEEK_END は直前の日曜日(%u は月=1..日=7 なので、その日数だけ戻ると必ず前の日曜になる)。
# 相対日付の指定(GNU: -d "-N days" / BSD: -v-Nd)は BusyBox date では使えないので epoch 秒で計算する。
# 今日の 12 時台に寄せてから日数分戻すので、夏時間の切り替えをまたいでも日付はずれない
# (1$$h - 100 は %H の先頭ゼロを外すため)。epoch → 日付は GNU/BusyBox が -d @N、BSD(macOS)が -r N。
LAST_WEEK_END := $(shell h=$$(date +%H); e=$$(( $$(date +%s) + (112 - 1$$h) * 3600 - $$(date +%u) * 86400 )); date -d "@$$e" +%Y%m%d 2>/dev/null || date -r "$$e" +%Y%m%d)
ARCHIVE_FILES := $(foreach f,$(wildcard memo-*.md),$(if $(shell [ $(patsubst memo-%.md,%,$(f)) -le $(LAST_WEEK_END) ] && echo y),$(f)))

.PHONY: all today create edit edit-with-code git-commit-files archive-files debug-vars setup-hooks scan help

all: today

today: create edit-with-code ## generate today's file from the latest file (if missing) and edit with VSCode

create: git-commit-files $(TODAY_FILE) ## commit untracked past files, then generate today's file

# 今日のファイルが無いときだけ最新ファイルから複製し、1 行目の日付見出しを書き換える
$(TODAY_FILE):
	cp $(LATEST_FILE) $@
	sed -i.bak "1s@.*@$(TODAY_HEADER)@" $@ && rm -f $@.bak

edit: $(TODAY_FILE) ## edit today's file with $EDITOR
	$(EDITOR) $<

# ターゲット固有変数は前提条件(edit)にも引き継がれる
edit-with-code: EDITOR := code
edit-with-code: edit ## edit today's file with VSCode

git-commit-files: ## git add and commit untracked memo files (one commit per file)
	@for f in $(UNTRACKED_MD); do git add "$$f" && git commit -m "$$f"; done

archive-files: ## git mv memo files older than this week into archives/YYYY/MM/
	@for f in $(ARCHIVE_FILES); do \
	    y=$$(echo "$$f" | cut -c6-9); m=$$(echo "$$f" | cut -c10-11); \
	    mkdir -p "archives/$$y/$$m" && git mv "$$f" "archives/$$y/$$m/"; \
	done

debug-vars: ## print variables
	@echo "latest:        $(LATEST_FILE)"
	@echo "today:         $(TODAY_FILE)"
	@echo "header:        $(TODAY_HEADER)"
	@echo "untracked:     $(UNTRACKED_MD)"
	@echo "editor:        $(EDITOR)"
	@echo "last_week_end: $(LAST_WEEK_END)"
	@echo "archive:       $(ARCHIVE_FILES)"

setup-hooks: ## enable pre-commit hook (gitleaks) for this clone
	git config core.hooksPath .githooks

scan: ## scan whole git history and working tree with gitleaks
	gitleaks git $(GITLEAKS_OPTS) .
	gitleaks dir $(GITLEAKS_OPTS) .

help:
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

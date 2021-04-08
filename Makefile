GCC = gcc

SRC_DIR   = src
BUILD_DIR = build

all: $(BUILD_DIR)/syntaxer

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h:
	bison -t -v -d -b $(BUILD_DIR)/parser $(SRC_DIR)/parser.y

$(BUILD_DIR)/lex.yy.c: $(SRC_DIR)/scaner.l
	flex -o $(BUILD_DIR)/lex.yy.c $(SRC_DIR)/scaner.l

$(BUILD_DIR)/syntaxer: $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h $(BUILD_DIR)/lex.yy.c
	gcc -o $(BUILD_DIR)/syntaxer $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/parser.tab.c

clean:
	rm -f $(BUILD_DIR)/*

run: $(BUILD_DIR)/syntaxer
	$(BUILD_DIR)/syntaxer

.PHONY: all clean run
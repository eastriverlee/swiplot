NAME=swiplot
SRC=src/*.swift

$(NAME): $(SRC)
	swiftc -o $(NAME) $(SRC)

run:
	./$(NAME)

.PHONY: run

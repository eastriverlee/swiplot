NAME=swiplot
SRC=src/*.swift

$(NAME): $(SRC)
	swiftc -o $(NAME) $(SRC)

run: $(NAME)
	./$(NAME)

clean:
	rm $(NAME)

.PHONY: run clean

NAME=swiplot
SRC=src/*.swift

width=480
height=480

$(NAME): $(SRC)
	swiftc -g -o $(NAME) $(SRC)

run: $(NAME)
	./$(NAME) $(width) $(height)

clean:
	rm -rf $(NAME) $(NAME).dSYM

.PHONY: run clean

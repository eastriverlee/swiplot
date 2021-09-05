NAME=swiplot
SRC=src/*.swift

width=480
height=480

$(NAME): $(SRC)
	swiftc -o $(NAME) $(SRC)

run: $(NAME)
	./$(NAME) $(width) $(height)

clean:
	rm $(NAME)

.PHONY: run clean

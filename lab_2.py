"""Lab 2 exercise"""
from typing import Any


def main():
    ask_again = True
    operations_count = 0

    while ask_again:
        a = input("Enter the numerator: ")
        b = input("Enter the denominator: ")
        try:
            result = perform_division(a, b)
        except ZeroDivisionError:
            result = "NAN"
        operations_count += 1
        print(result)
        ask_again = input(
            "Do you want to perform another operation? Enter yes or no: "
        )
        if ask_again == "yes":
            ask_again = True
        else:
            ask_again = False
            print(
                "You performed " + str(operations_count) + " operations, bye!"
            )


def perform_division(a: Any, b: Any) -> float:
    return int(a) / int(b)

main()

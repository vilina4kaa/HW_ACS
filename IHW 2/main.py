import math

def factorial(n):
    if n == 0 or n == 1:
        return 1
    return n * factorial(n - 1)


def double_factorial(n):
    if n <= 0:
        return 1
    return n * double_factorial(n - 2)


def sqrt_taylor_series(x, accuracy=0.0005):
    a = int(x)
    if a == -1:
        a = 0
        if x == -1:
            return float(0)

    term = math.sqrt(1 + a)
    sum_series = term
    n = 1

    dx = x - a

    while True:
        sign = (-1) ** (n - 1)
        numerator = double_factorial(2 * n - 3)
        denominator = (2 ** n) * factorial(n) * (1 + a) ** (n - 0.5)
        term = sign * (numerator / denominator) * (dx ** n)

        new_sum = sum_series + term

        if abs(new_sum - sum_series) <= accuracy * abs(new_sum):
            break

        sum_series = new_sum
        n += 1

    return new_sum

a = [-0.85, -1, 3.96, 0, 67, 99, 1984, 0.59]
b = [0.387298334620742, 0.0, 2.227105745132009, 1.0, 8.246211251235321,
     10.0, 44.55333881989093, 1.260952021291849]
c = [0.0005, 0.0000005, 0.0000000005]
i = 0
for x in a:
    if (i != 1 and i != 3 and i != 5):
        for accuracy in c:
            result = sqrt_taylor_series(x, accuracy)
            print(f"x = {x}")
            print(f"epsilon = {accuracy}")
            print(f"expected = {b[i]}")
            print(f"sqrt(1 + x) = {result} \n")
    else:
        accuracy = 0.0005
        result = sqrt_taylor_series(x, accuracy)
        print(f"x = {x}")
        print(f"epsilon = {accuracy}")
        print(f"expected = {b[i]}")
        print(f"sqrt(1 + x) = {result} \n")
    i += 1


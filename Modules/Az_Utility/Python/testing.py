def prime_derivatives(numbers):
  def is_prime(n):
    if n < 2:
      return False
    for i in range(2, int(n ** 0.5) + 1):
      if n % i == 0:
        return False
    return True

  prime_derivatives = []
  for number in numbers:
    derivative = number
    while not is_prime(derivative):
      for i in range(2, derivative):
        if derivative % i == 0:
          derivative //= i
          break
    prime_derivatives.append(derivative)
  return prime_derivatives

print(prime_derivatives([20]))
int acm (int n)
{
    if (n == 0) return 0;
    return n + acm(n - 1);
}

int fib(int n)
{
    int a, b;
    a = 0;
    b = 1;
    for (int i = 0; i < n; i++) {
        int tmp = b;
        b = a + b;
        a = tmp;
    }
    return a;
}

int main ()
{
    return fib(30);
}

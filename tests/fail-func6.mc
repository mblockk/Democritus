function void foo(int a, bool b)
{
}

function int main()
{
  foo(42, true);
  foo(42); /* Wrong number of arguments */
}

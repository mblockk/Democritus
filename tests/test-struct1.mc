struct Rectangle
{
  int width;
  int height;
}

struct Circle
{
  int radius;
  struct Rectangle r;
}

function int main()
{
  bool b;
  struct Circle x;
  print("hello world\n");
  return 0;
}

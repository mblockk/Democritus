function main() int
{
  let fd int;
  fd = open("tests/HELLOOOOOO.txt", 66);
  write(fd, "hellooo!\n", 9);

  return 0;
}
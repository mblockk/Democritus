function main() int
{
  let fd int;
  let malloced string;
  fd = open("tests/HELLOOOOOO.txt", 66);
  malloced = malloc(10);  
  read(fd, malloced, 10);
  print(malloced);

  return 0;
}

#include <cstdio>

int main(int argc, char *argv[])
{
	FILE * in = fopen(argv[1], "r");
	FILE * out = fopen(argv[2], "w");
	char c;
	while ((c = fgetc(in)) != EOF)
	{
		if (c == ' ')
			fputc('\t', out);
		else
			fputc(c, out);
	}
}
#include <stdio.h>
int _sumAndPrintList(int *list, int length);

int main()
{
	int num[1000];
	int counter = 0;
	int i;
	int total = 0;

	printf("Enter 0 to end getting input\n");
	for(i=0; i < 1000; i++)
	{
	printf("Enter a number: ");
	scanf("%d", &num[i]);
	counter++;
		if(num[i] == 0)
		{
			printf("Ending input...\n");
			i = 1001;
		}
	}
	for(i=0; i < counter; i++)
{
	printf("%d\n", num[i]);
}
	total = _sumAndPrintList(num, counter);
	printf("The goddam total is: %d\n",total);
}

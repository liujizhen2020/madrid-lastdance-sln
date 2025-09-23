#import <Foundation/Foundation.h>
#import "MaydayChecker.h"

int main(int argc, char **argv, char **envp) {
	MaydayChecker *sos = [MaydayChecker new];
	[sos check];
	return 0;
}


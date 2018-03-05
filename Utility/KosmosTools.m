//
//  KosmosTools.m
//  mxt1707s
//
//  Created by weizhen on 2017/11/23.
//  Copyright © 2017年 weizhen. All rights reserved.
//

#import "KosmosTools.h"

// 校验IMEI
BOOL checkIMEI(NSString *string) {
    
    unichar *characters = (unichar *)malloc(string.length * sizeof(unichar));
    [string getCharacters:characters];
    
    int resultInt = 0;
    for (int i = 0; i < 14; i++) {
        int a = characters[i] - 48;
        i++;
        int b = (characters[i] - 48) * 2;
        int c = (b < 10) ? b : (b - 9);
        resultInt += a + c;
    }
    resultInt %= 10;
    resultInt = (resultInt == 0) ?0 : (10 - resultInt);
    
    BOOL ret = (characters[14] - 48) == resultInt;
    free(characters);
    return ret;
}

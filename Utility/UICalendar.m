//
//  UICalendar.m
//  UICalendar
//
//  Created by weizhen on 16/9/27.
//  Copyright © 2016年 whmx. All rights reserved.
//

#import "UICalendar.h"

@implementation UIColor (Kosmos)

/** 根据十六进制数字生成颜色 */
+ (instancetype)colorWithHexInteger:(NSInteger)hexInteger alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hexInteger >> 16) & 0xFF) / 255.0 green:((hexInteger >> 8) & 0xFF) / 255.0 blue:((hexInteger) & 0xFF) / 255.0 alpha:alpha];
}

@end

@interface UICalendar () {
    NSMutableArray<UIButton *> *_heads; // 1*7个表示星期的按钮
    NSMutableArray<UIButton *> *_cells; // 6*7个表示日期的按钮
    NSMutableArray<UIButton *> *_foots; // 1*7个表示功能的按钮
    NSDate *_date; // 被选中的日期
    NSInteger _select; // 被选中的序号
    NSInteger _offset; // 序号 = 日期 + 偏移
    NSInteger _count; // 日期的最大数
}

@end

@implementation UICalendar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        uint8_t calendar_cell_nn[] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x05, 0x08, 0x02, 0x00, 0x00, 0x00, 0x02, 0x0d, 0xb1, 0xb2, 0x00, 0x00, 0x00, 0x19, 0x74, 0x45, 0x58, 0x74, 0x53, 0x6f, 0x66, 0x74, 0x77, 0x61, 0x72, 0x65, 0x00, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x49, 0x6d, 0x61, 0x67, 0x65, 0x52, 0x65, 0x61, 0x64, 0x79, 0x71, 0xc9, 0x65, 0x3c, 0x00, 0x00, 0x03, 0x24, 0x69, 0x54, 0x58, 0x74, 0x58, 0x4d, 0x4c, 0x3a, 0x63, 0x6f, 0x6d, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x78, 0x6d, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3c, 0x3f, 0x78, 0x70, 0x61, 0x63, 0x6b, 0x65, 0x74, 0x20, 0x62, 0x65, 0x67, 0x69, 0x6e, 0x3d, 0x22, 0xef, 0xbb, 0xbf, 0x22, 0x20, 0x69, 0x64, 0x3d, 0x22, 0x57, 0x35, 0x4d, 0x30, 0x4d, 0x70, 0x43, 0x65, 0x68, 0x69, 0x48, 0x7a, 0x72, 0x65, 0x53, 0x7a, 0x4e, 0x54, 0x63, 0x7a, 0x6b, 0x63, 0x39, 0x64, 0x22, 0x3f, 0x3e, 0x20, 0x3c, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x6d, 0x65, 0x74, 0x61, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x3d, 0x22, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x3a, 0x6e, 0x73, 0x3a, 0x6d, 0x65, 0x74, 0x61, 0x2f, 0x22, 0x20, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x74, 0x6b, 0x3d, 0x22, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x58, 0x4d, 0x50, 0x20, 0x43, 0x6f, 0x72, 0x65, 0x20, 0x35, 0x2e, 0x33, 0x2d, 0x63, 0x30, 0x31, 0x31, 0x20, 0x36, 0x36, 0x2e, 0x31, 0x34, 0x35, 0x36, 0x36, 0x31, 0x2c, 0x20, 0x32, 0x30, 0x31, 0x32, 0x2f, 0x30, 0x32, 0x2f, 0x30, 0x36, 0x2d, 0x31, 0x34, 0x3a, 0x35, 0x36, 0x3a, 0x32, 0x37, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x22, 0x3e, 0x20, 0x3c, 0x72, 0x64, 0x66, 0x3a, 0x52, 0x44, 0x46, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x72, 0x64, 0x66, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x77, 0x33, 0x2e, 0x6f, 0x72, 0x67, 0x2f, 0x31, 0x39, 0x39, 0x39, 0x2f, 0x30, 0x32, 0x2f, 0x32, 0x32, 0x2d, 0x72, 0x64, 0x66, 0x2d, 0x73, 0x79, 0x6e, 0x74, 0x61, 0x78, 0x2d, 0x6e, 0x73, 0x23, 0x22, 0x3e, 0x20, 0x3c, 0x72, 0x64, 0x66, 0x3a, 0x44, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x72, 0x64, 0x66, 0x3a, 0x61, 0x62, 0x6f, 0x75, 0x74, 0x3d, 0x22, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x6d, 0x70, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x6d, 0x6d, 0x2f, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x73, 0x54, 0x79, 0x70, 0x65, 0x2f, 0x52, 0x65, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x52, 0x65, 0x66, 0x23, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x3a, 0x43, 0x72, 0x65, 0x61, 0x74, 0x6f, 0x72, 0x54, 0x6f, 0x6f, 0x6c, 0x3d, 0x22, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x50, 0x68, 0x6f, 0x74, 0x6f, 0x73, 0x68, 0x6f, 0x70, 0x20, 0x43, 0x53, 0x36, 0x20, 0x28, 0x4d, 0x61, 0x63, 0x69, 0x6e, 0x74, 0x6f, 0x73, 0x68, 0x29, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x49, 0x6e, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x69, 0x69, 0x64, 0x3a, 0x30, 0x44, 0x42, 0x33, 0x38, 0x35, 0x37, 0x46, 0x37, 0x44, 0x37, 0x33, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x44, 0x6f, 0x63, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x64, 0x69, 0x64, 0x3a, 0x30, 0x44, 0x42, 0x33, 0x38, 0x35, 0x38, 0x30, 0x37, 0x44, 0x37, 0x33, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x3e, 0x20, 0x3c, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x44, 0x65, 0x72, 0x69, 0x76, 0x65, 0x64, 0x46, 0x72, 0x6f, 0x6d, 0x20, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3a, 0x69, 0x6e, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x69, 0x69, 0x64, 0x3a, 0x30, 0x44, 0x42, 0x33, 0x38, 0x35, 0x37, 0x44, 0x37, 0x44, 0x37, 0x33, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x20, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3a, 0x64, 0x6f, 0x63, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x64, 0x69, 0x64, 0x3a, 0x30, 0x44, 0x42, 0x33, 0x38, 0x35, 0x37, 0x45, 0x37, 0x44, 0x37, 0x33, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x2f, 0x3e, 0x20, 0x3c, 0x2f, 0x72, 0x64, 0x66, 0x3a, 0x44, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x3e, 0x20, 0x3c, 0x2f, 0x72, 0x64, 0x66, 0x3a, 0x52, 0x44, 0x46, 0x3e, 0x20, 0x3c, 0x2f, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x6d, 0x65, 0x74, 0x61, 0x3e, 0x20, 0x3c, 0x3f, 0x78, 0x70, 0x61, 0x63, 0x6b, 0x65, 0x74, 0x20, 0x65, 0x6e, 0x64, 0x3d, 0x22, 0x72, 0x22, 0x3f, 0x3e, 0xf7, 0x4b, 0xae, 0xbd, 0x00, 0x00, 0x00, 0x48, 0x49, 0x44, 0x41, 0x54, 0x78, 0xda, 0x62, 0x7c, 0xfd, 0xeb, 0xc7, 0x7f, 0x06, 0x10, 0x60, 0x04, 0x42, 0x86, 0xff, 0x8c, 0xb7, 0x7f, 0x7c, 0x99, 0xf5, 0xe7, 0x8d, 0x20, 0x03, 0xf3, 0x6b, 0x86, 0xdf, 0x59, 0x2c, 0x62, 0x2c, 0xbf, 0x19, 0xfe, 0x4b, 0x32, 0xb2, 0xb2, 0x31, 0x30, 0x32, 0x31, 0x30, 0xfc, 0x65, 0xf8, 0xcf, 0xc2, 0xca, 0xc0, 0xf8, 0xfc, 0xff, 0x6f, 0x88, 0x3c, 0x33, 0x03, 0x23, 0x23, 0x9a, 0x7e, 0x80, 0x00, 0x03, 0x00, 0x84, 0x02, 0x1a, 0x90, 0xaa, 0x28, 0x5a, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82};
        uint8_t calendar_cell_sn[] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x05, 0x08, 0x02, 0x00, 0x00, 0x00, 0x02, 0x0d, 0xb1, 0xb2, 0x00, 0x00, 0x00, 0x19, 0x74, 0x45, 0x58, 0x74, 0x53, 0x6f, 0x66, 0x74, 0x77, 0x61, 0x72, 0x65, 0x00, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x49, 0x6d, 0x61, 0x67, 0x65, 0x52, 0x65, 0x61, 0x64, 0x79, 0x71, 0xc9, 0x65, 0x3c, 0x00, 0x00, 0x03, 0x24, 0x69, 0x54, 0x58, 0x74, 0x58, 0x4d, 0x4c, 0x3a, 0x63, 0x6f, 0x6d, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x78, 0x6d, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3c, 0x3f, 0x78, 0x70, 0x61, 0x63, 0x6b, 0x65, 0x74, 0x20, 0x62, 0x65, 0x67, 0x69, 0x6e, 0x3d, 0x22, 0xef, 0xbb, 0xbf, 0x22, 0x20, 0x69, 0x64, 0x3d, 0x22, 0x57, 0x35, 0x4d, 0x30, 0x4d, 0x70, 0x43, 0x65, 0x68, 0x69, 0x48, 0x7a, 0x72, 0x65, 0x53, 0x7a, 0x4e, 0x54, 0x63, 0x7a, 0x6b, 0x63, 0x39, 0x64, 0x22, 0x3f, 0x3e, 0x20, 0x3c, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x6d, 0x65, 0x74, 0x61, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x3d, 0x22, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x3a, 0x6e, 0x73, 0x3a, 0x6d, 0x65, 0x74, 0x61, 0x2f, 0x22, 0x20, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x74, 0x6b, 0x3d, 0x22, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x58, 0x4d, 0x50, 0x20, 0x43, 0x6f, 0x72, 0x65, 0x20, 0x35, 0x2e, 0x33, 0x2d, 0x63, 0x30, 0x31, 0x31, 0x20, 0x36, 0x36, 0x2e, 0x31, 0x34, 0x35, 0x36, 0x36, 0x31, 0x2c, 0x20, 0x32, 0x30, 0x31, 0x32, 0x2f, 0x30, 0x32, 0x2f, 0x30, 0x36, 0x2d, 0x31, 0x34, 0x3a, 0x35, 0x36, 0x3a, 0x32, 0x37, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x22, 0x3e, 0x20, 0x3c, 0x72, 0x64, 0x66, 0x3a, 0x52, 0x44, 0x46, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x72, 0x64, 0x66, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x77, 0x33, 0x2e, 0x6f, 0x72, 0x67, 0x2f, 0x31, 0x39, 0x39, 0x39, 0x2f, 0x30, 0x32, 0x2f, 0x32, 0x32, 0x2d, 0x72, 0x64, 0x66, 0x2d, 0x73, 0x79, 0x6e, 0x74, 0x61, 0x78, 0x2d, 0x6e, 0x73, 0x23, 0x22, 0x3e, 0x20, 0x3c, 0x72, 0x64, 0x66, 0x3a, 0x44, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x72, 0x64, 0x66, 0x3a, 0x61, 0x62, 0x6f, 0x75, 0x74, 0x3d, 0x22, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x6d, 0x70, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x6d, 0x6d, 0x2f, 0x22, 0x20, 0x78, 0x6d, 0x6c, 0x6e, 0x73, 0x3a, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3d, 0x22, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x6e, 0x73, 0x2e, 0x61, 0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x78, 0x61, 0x70, 0x2f, 0x31, 0x2e, 0x30, 0x2f, 0x73, 0x54, 0x79, 0x70, 0x65, 0x2f, 0x52, 0x65, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x52, 0x65, 0x66, 0x23, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x3a, 0x43, 0x72, 0x65, 0x61, 0x74, 0x6f, 0x72, 0x54, 0x6f, 0x6f, 0x6c, 0x3d, 0x22, 0x41, 0x64, 0x6f, 0x62, 0x65, 0x20, 0x50, 0x68, 0x6f, 0x74, 0x6f, 0x73, 0x68, 0x6f, 0x70, 0x20, 0x43, 0x53, 0x36, 0x20, 0x28, 0x4d, 0x61, 0x63, 0x69, 0x6e, 0x74, 0x6f, 0x73, 0x68, 0x29, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x49, 0x6e, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x69, 0x69, 0x64, 0x3a, 0x38, 0x34, 0x37, 0x33, 0x31, 0x34, 0x43, 0x36, 0x37, 0x44, 0x37, 0x32, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x20, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x44, 0x6f, 0x63, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x64, 0x69, 0x64, 0x3a, 0x30, 0x44, 0x42, 0x33, 0x38, 0x35, 0x37, 0x43, 0x37, 0x44, 0x37, 0x33, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x3e, 0x20, 0x3c, 0x78, 0x6d, 0x70, 0x4d, 0x4d, 0x3a, 0x44, 0x65, 0x72, 0x69, 0x76, 0x65, 0x64, 0x46, 0x72, 0x6f, 0x6d, 0x20, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3a, 0x69, 0x6e, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x69, 0x69, 0x64, 0x3a, 0x38, 0x34, 0x37, 0x33, 0x31, 0x34, 0x43, 0x34, 0x37, 0x44, 0x37, 0x32, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x20, 0x73, 0x74, 0x52, 0x65, 0x66, 0x3a, 0x64, 0x6f, 0x63, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x44, 0x3d, 0x22, 0x78, 0x6d, 0x70, 0x2e, 0x64, 0x69, 0x64, 0x3a, 0x38, 0x34, 0x37, 0x33, 0x31, 0x34, 0x43, 0x35, 0x37, 0x44, 0x37, 0x32, 0x31, 0x31, 0x45, 0x36, 0x41, 0x36, 0x46, 0x38, 0x43, 0x36, 0x30, 0x41, 0x41, 0x41, 0x43, 0x42, 0x42, 0x46, 0x36, 0x33, 0x22, 0x2f, 0x3e, 0x20, 0x3c, 0x2f, 0x72, 0x64, 0x66, 0x3a, 0x44, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x3e, 0x20, 0x3c, 0x2f, 0x72, 0x64, 0x66, 0x3a, 0x52, 0x44, 0x46, 0x3e, 0x20, 0x3c, 0x2f, 0x78, 0x3a, 0x78, 0x6d, 0x70, 0x6d, 0x65, 0x74, 0x61, 0x3e, 0x20, 0x3c, 0x3f, 0x78, 0x70, 0x61, 0x63, 0x6b, 0x65, 0x74, 0x20, 0x65, 0x6e, 0x64, 0x3d, 0x22, 0x72, 0x22, 0x3f, 0x3e, 0xcc, 0x9b, 0x64, 0xcb, 0x00, 0x00, 0x00, 0x52, 0x49, 0x44, 0x41, 0x54, 0x78, 0xda, 0x3c, 0xcb, 0x31, 0x0e, 0x40, 0x40, 0x14, 0x04, 0xd0, 0x99, 0xfd, 0x3f, 0x74, 0x2a, 0x2a, 0x91, 0x08, 0xce, 0xe7, 0xa4, 0x2e, 0x20, 0x91, 0xed, 0x74, 0x2e, 0xb0, 0x1b, 0x6b, 0x14, 0x12, 0xf5, 0xcb, 0xe3, 0xba, 0x6f, 0x29, 0x67, 0x90, 0x04, 0xcd, 0xcc, 0x8f, 0xeb, 0x8c, 0x31, 0x06, 0xa0, 0x48, 0xf3, 0x38, 0x79, 0x11, 0xbc, 0xaa, 0x83, 0x40, 0x3d, 0x0f, 0xe5, 0x46, 0xdc, 0x39, 0x7d, 0x1e, 0x44, 0x5f, 0xda, 0x7e, 0x68, 0xba, 0xff, 0xbf, 0x02, 0x0c, 0x00, 0x31, 0x0d, 0x1c, 0x64, 0x5c, 0xd7, 0x2b, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82};
        NSData *data_nn  = [NSData dataWithBytes:calendar_cell_nn length:sizeof(calendar_cell_nn)/sizeof(uint8_t)];
        NSData *data_sn  = [NSData dataWithBytes:calendar_cell_sn length:sizeof(calendar_cell_sn)/sizeof(uint8_t)];
        UIImage *cell_nn = [[UIImage imageWithData:data_nn] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        UIImage *cell_sn = [[UIImage imageWithData:data_sn] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        
        _heads = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            NSString *title = @"";
            switch (i) {
                case 0:  {title = @"日"; break;}
                case 1:  {title = @"一"; break;}
                case 2:  {title = @"二"; break;}
                case 3:  {title = @"三"; break;}
                case 4:  {title = @"四"; break;}
                case 5:  {title = @"五"; break;}
                case 6:  {title = @"六"; break;}
                default: {title = @"十"; break;}
            }
            UIButton *button = [UIButton new];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.backgroundColor = [UIColor colorWithHexInteger:0xd85d71 alpha:1.0];
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [UIColor colorWithHexInteger:0x972b37 alpha:1.0].CGColor;
            [button setTitle:title forState:UIControlStateNormal];
            [self addSubview:button];
            [_heads addObject:button];
        }
        
        _cells = [NSMutableArray array];
        for (int i = 0; i < 7 * 6; i++) {
            UIButton *button = [UIButton new];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:cell_nn forState:UIControlStateNormal];
            [button setBackgroundImage:cell_sn forState:UIControlStateSelected];
            [button addTarget:self action:@selector(someDayPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [_cells addObject:button];
        }
        
        _foots = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            UIButton *button = [UIButton new];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.backgroundColor = [UIColor colorWithHexInteger:0xd85d71 alpha:1.0];
            [self addSubview:button];
            [_foots addObject:button];
            
            if (i == 0) {
                [button setTitle:@"上个月" forState:UIControlStateNormal];
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexInteger:0x972b37 alpha:1.0].CGColor;
                [button addTarget:self action:@selector(prevMonthPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            if (i == 1) {
                [button setTitle:@"上一年" forState:UIControlStateNormal];
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexInteger:0x972b37 alpha:1.0].CGColor;
                [button addTarget:self action:@selector(prevYearPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            if (i == 5) {
                [button setTitle:@"下一年" forState:UIControlStateNormal];
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexInteger:0x972b37 alpha:1.0].CGColor;
                [button addTarget:self action:@selector(nextYearPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            if (i == 6) {
                [button setTitle:@"下个月" forState:UIControlStateNormal];
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexInteger:0x972b37 alpha:1.0].CGColor;
                [button addTarget:self action:@selector(nextMonthPressed) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        self.date = [NSDate date];
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    
    if (date == nil) {
        _date = [NSDate date];
    } else {
        _date = date;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 本月一共多少天
    _count = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:_date].length;
    
    // 本月第一天是什么时间
    NSDate *startDate = nil;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:_date];
    
    // 本月第一天是星期几
    _offset = [calendar components:NSCalendarUnitWeekday fromDate:startDate].weekday - 2;
    
    // 选中的是哪一个
    _select = [calendar components:NSCalendarUnitDay fromDate:date].day + _offset;
    
    // 重新布局
    [self setNeedsLayout];
}

- (void)prevYearPressed {
    NSDateComponents *comp = [NSDateComponents new];
    comp.year = -1;
    self.date = [NSCalendar.currentCalendar dateByAddingComponents:comp toDate:self.date options:0];
    [self.delegate calendar:self selectDate:self.date];
    
    
}

- (void)nextYearPressed {
    NSDateComponents *comp = [NSDateComponents new];
    comp.year = 1;
    self.date = [NSCalendar.currentCalendar dateByAddingComponents:comp toDate:self.date options:0];
    [self.delegate calendar:self selectDate:self.date];
}

- (void)prevMonthPressed {
    NSDateComponents *comp = [NSDateComponents new];
    comp.month = -1;
    self.date = [NSCalendar.currentCalendar dateByAddingComponents:comp toDate:self.date options:0];
    [self.delegate calendar:self selectDate:self.date];
}

- (void)nextMonthPressed {
    NSDateComponents *comp = [NSDateComponents new];
    comp.month = 1;
    self.date = [NSCalendar.currentCalendar dateByAddingComponents:comp toDate:self.date options:0];
    [self.delegate calendar:self selectDate:self.date];
}

- (void)someDayPressed:(UIButton *)sender {
    
    NSInteger index = [_cells indexOfObject:sender];
    
    if (index > _count + _offset) {
        return;
    }
    
    if (index < 1 + _offset) {
        return;
    }
    
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = index - _select;
    self.date = [NSCalendar.currentCalendar dateByAddingComponents:comp toDate:self.date options:0];
    [self.delegate calendar:self selectDate:self.date];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSUInteger maxCols = 7;
    NSUInteger maxRows = 8;
    CGFloat selfw = self.bounds.size.width;
    CGFloat selfh = self.bounds.size.height;
    CGFloat cellw = selfw / maxCols;
    CGFloat cellh = selfh / maxRows;
    
    for (NSUInteger row = 0; row < maxRows; row++) {
        
        for (NSUInteger col = 0; col < maxCols; col ++) {
            
            if (row == 0) {
                UIButton *button = [_heads objectAtIndex:col];
                button.frame = CGRectMake(col * cellw, row * cellh, cellw, cellh);
            }
            
            else if (row == 7) {
                UIButton *button = [_foots objectAtIndex:col];
                button.frame = CGRectMake(col * cellw, row * cellh, cellw, cellh);
            }
            
            else {
                
                NSUInteger index = row * maxCols + col - maxCols;
                UIButton *button = [_cells objectAtIndex:index];
                
                button.frame = CGRectMake(col * cellw, row * cellh, cellw, cellh);
                button.selected = (index == _select);
                
                NSUInteger dayno = index -_offset;
                NSString *nnTitle = (dayno <= _count && dayno > 0) ? @(dayno).stringValue : @"";
                [button setTitle:nnTitle forState:UIControlStateNormal];
            }
        }
    }
}

@end

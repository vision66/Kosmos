//
//  dispatch+Silence9x.m
//  StudentCard
//
//  Created by weizhen on 16/6/16.
//  Copyright © 2016年 vision66. All rights reserved.
//

#import "dispatch+Kosmos.h"

void dispatch_asyn_on_main(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static void *kPriorityDefaultGlobalQueueKey = "kPriorityDefaultGlobalQueueKey";

void dispatch_asyn_on_global(dispatch_block_t block) {
    if (dispatch_get_specific(kPriorityDefaultGlobalQueueKey)) {
        block();
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_set_specific(queue, kPriorityDefaultGlobalQueueKey, (void *)kPriorityDefaultGlobalQueueKey, NULL);
        dispatch_async(queue, block);
    }
}

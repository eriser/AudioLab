//
//  RingBuffer.h
//  VoiceTrack
//
//  Created by Ness on 8/11/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

////--- Utility operations
//#define RingBuffer_available_data(B) (((B)->end + 1) % (B)->length - (B)->start - 1)  //que pasa cuando no se lee completamente
#define RingBuffer_available_data(B) ((B)->end  - (B)->start)
#define RingBuffer_available_space(B) ((B)->length - (B)->end - 1)
#define RingBuffer_commit_write(B, A) ((B)->end = ((B)->end + (A)) % (B)->length)
#define RingBuffer_commit_read(B, A) ((B)->start = ((B)->start + (A)) % (B)->length)
#define RingBuffer_ends_at(B) ((B)->buffer + (B)->end)
#define RingBuffer_starts_at(B) ((B)->buffer + (B)->start)

#define RingBuffer_full(B) (RingBuffer_available_data((B)) - (B)->length == 0)
////--- Buffer Structure

typedef struct{
    float *buffer;    //Float type is 4-bytes size
    int length;
    int start;
    int end;
}RingBuffer;


///////
//RingBuffer* RingBuffer_create(int length);
//int RingBuffer_write (RingBuffer* buffer, float* data, int length);
//int RingBuffer_read(RingBuffer *buffer, float *target, int amount);
//int getStartIndex(RingBuffer *buffer);
//int getEndIndex(RingBuffer *buffer);
//int getAvailableData(RingBuffer *buffer);



//
//  RingBuffer.c
//  VoiceTrack
//
//  Created by Ness on 8/11/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include "RingBuffer.h"
#include <MacTypes.h>
////--- Create a ring buffer
RingBuffer* RingBuffer_create(int length){
    RingBuffer *buffer= calloc(1,sizeof(RingBuffer));
    buffer->length=length+1;
    buffer->start = 0;
    buffer->end = 0;
    buffer->buffer=calloc(buffer->length,sizeof(Float32));
    return buffer;
}

////--- Write to buffer
int RingBuffer_write (RingBuffer* buffer, float* data, int length){
    //buffer --> The buffer where to right
    //data   --> A pointer to the memory containing the data to be written
    //length --> This is the total number of BYTES to be copied.(Used in memcpy)
    //           Length is defined by: [the number of elements in data]x[size of each element]
    
    // First check if there is available data , if not, reset the indexes to 0
    if(RingBuffer_available_data(buffer) == 0) {
        buffer->start = buffer->end = 0;
        //printf("start=end=0 from write\n");
    }
    
    //check if the number of input elements is greater thant the space left in buffer
    if(length > RingBuffer_available_space(buffer)){
        printf("Not enough space, ocuppied: %d of:%d, inputOf: %d",
               RingBuffer_available_data(buffer), buffer->length,length);
        return -1;
    }
    
    //if it is save to write you can proceed
    void *result = memcpy(RingBuffer_ends_at(buffer), data, length*sizeof(float));
    if (result==NULL) {
        printf("Failed to write data into buffer.");
    }
    //Commit the write operation
    RingBuffer_commit_write(buffer, length);
    
    //return the number of elements written
    return length;
}

////--- Read buffer
int RingBuffer_read(RingBuffer *buffer, float *target, int amount){
    if (amount > RingBuffer_available_data(buffer)) {
        printf("Not enough in the buffer: has %d, needs %d", RingBuffer_available_data(buffer), amount);
        return -1;
    }
    void *result = memcpy(target, RingBuffer_starts_at(buffer), amount*sizeof(float));
    if (result==NULL) {
        printf("Failed to write buffer into data.");
    }
    RingBuffer_commit_read(buffer, amount);
    
    if(buffer->end == buffer->start) {
        buffer->start = buffer->end = 0;
        //printf("start=end=0 from read\n");
    }
    return amount;
    
}

int getAvailableData(RingBuffer *buffer){
    return RingBuffer_available_data(buffer);
}
int getStartIndex(RingBuffer *buffer){
    return buffer->start;
}
int getEndIndex(RingBuffer *buffer){
    return buffer->end;
}




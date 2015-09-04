//
//  FIFO.h
//  Synth_Osc2
//
//  Created by Ness on 8/20/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#ifndef __Synth_Osc2__FIFO__
#define __Synth_Osc2__FIFO__

#include <stdio.h>



class FIFO;

class Node{
    friend class FIFO;
public:
    Node(float val):data(val),next(NULL){};
    ~Node(){};
private:
    float data;
    Node* next;
};

class FIFO{
public:
    FIFO():first(NULL),last(NULL),size(0){};
    ~FIFO();
    
    inline void enqueue(float val){
        Node* newNode= new Node(val);
        if (isEmpty()) {
            first=last=newNode;
        }else{
            last->next=newNode;
            last=newNode;
        }
        ++size;
    }
    
    
    inline float dequeue(){
        float output;
        if (!isEmpty()) {
            Node *temp= first;
            output=first->data;
            if (first==last) {
                first=last=0;
            }else{
                first=first->next;
            }
            --size;
            delete temp;
        }else{
            printf("queue is empty\n");
            output=0.0;
        }
        return output;
    }
    
    inline bool isEmpty(){return first==NULL;};
    
    //    void printFIFO(){
    //        if (!isEmpty()) {
    //            Node* curr=first;
    //            while (curr!=NULL) {
    //                printf("%f -> ",curr->data);
    //                curr=curr->next;
    //            }
    //        }else{
    //            printf("Queue is Empty");
    //        }
    //        printf("\n");
    //    }
    
private:
    Node *first;
    Node *last;
public:
    int size;
};

#endif /* defined(__Synth_Osc2__FIFO__) */

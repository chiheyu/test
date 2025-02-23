#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 定义哈希表的大小
#define TABLE_SIZE 10

// 定义链表节点结构体
typedef struct Node {
    int key;          // 节点存储的键值
    struct Node* next; // 指向下一个节点的指针
} Node;

// 定义哈希表结构体
typedef struct {
    Node* table[TABLE_SIZE]; // 存储链表头指针的数组
} HashTable;

// 初始化哈希表
void initHashTable(HashTable* ht) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        ht->table[i] = NULL; // 将每个链表头指针初始化为NULL
    }
}

// 哈希函数
int hashFunction(int key) {
    return key % TABLE_SIZE; // 使用取模运算计算哈希值
}

// 插入元素到哈希表
void insert(HashTable* ht, int key) {
    int index = hashFunction(key); // 计算插入位置的索引
    Node* newNode = (Node*)malloc(sizeof(Node)); // 分配新节点的内存
    newNode->key = key; // 设置新节点的键值
    newNode->next = ht->table[index]; // 将新节点插入到链表头部
    ht->table[index] = newNode; // 更新链表头指针
}

// 在哈希表中查找元素
int search(HashTable* ht, int key) {
    int index = hashFunction(key); // 计算查找位置的索引
    Node* current = ht->table[index]; // 获取链表头指针
    while (current != NULL) {
        if (current->key == key) {
            return 1; // 找到元素，返回1
        }
        current = current->next; // 移动到下一个节点
    }
    return 0; // 未找到元素，返回0
}

// 计算哈希查找的平均查找长度
double calculateASL(HashTable* ht) {
    int totalComparisons = 0; // 总比较次数
    int totalElements = 0;    // 总元素数量
    for (int i = 0; i < TABLE_SIZE; i++) {
        Node* current = ht->table[i]; // 获取链表头指针
        int count = 0; // 当前链表的比较次数
        while (current != NULL) {
            count++; // 增加当前链表的比较次数
            totalComparisons += count; // 累加到总比较次数
            totalElements++; // 增加总元素数量
            current = current->next; // 移动到下一个节点
        }
    }
    if (totalElements == 0) {
        return 0; // 如果没有元素，返回0
    }
    return (double)totalComparisons / totalElements; // 计算并返回平均查找长度
}

// 释放哈希表内存
void freeHashTable(HashTable* ht) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        Node* current = ht->table[i]; // 获取链表头指针
        while (current != NULL) {
            Node* temp = current; // 临时保存当前节点
            current = current->next; // 移动到下一个节点
            free(temp); // 释放当前节点的内存
        }
    }
}

int main() {
    HashTable ht;
    initHashTable(&ht); // 初始化哈希表

    // 插入一些元素
    insert(&ht, 12);
    insert(&ht, 22);
    insert(&ht, 32);
    insert(&ht, 42);

    // 查找元素
    if (search(&ht, 22)) {
        printf("元素22找到了\n"); // 如果找到，打印提示信息
    } else {
        printf("元素22未找到\n"); // 如果未找到，打印提示信息
    }

    // 计算平均查找长度
    double asl = calculateASL(&ht);
    printf("平均查找长度ASL: %.2f\n", asl); // 打印平均查找长度

    // 释放哈希表内存
    freeHashTable(&ht);

    return 0;
}


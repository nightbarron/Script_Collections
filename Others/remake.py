def main():
    data={0,1,1,0,1,0,0,0,0,1,1,0,0,1,0,1,0,1,1,0,1,1,0,0,0,1,1,0,1,1,0,0,0,1,1,0,1,1,1,1,0,0,1,1,0,1,1,1,0,0,1,1,0,1,1,1,0,0,1,1,1,0,0,1}
    index={58,50	,42,	34,	26,	18,	10,	2,60,	52,	44,	36,	28,	20,	12,	4,62,	54,	46,	38,	30,	22,	14,	6
,64,	56,	48,	40,	32	,24,	16	,8,
57,	49,	41,	33,	25	,17,	9	,1,
59,	51,	43,	35,	27,	19	,11,	3,
61,	53,	45,	37,	29,	21,	13,	5,
63,	55,	47,	39,	31,	23,	15,	7
}
    print(len(data))
    for i in range(1,len(data)):
        if (i % 8 == 0):
            print("\n",data[index[i - 1]])
    return 0

main()
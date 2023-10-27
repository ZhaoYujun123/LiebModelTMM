import matplotlib.pyplot as plt
import random
import numpy as np
import pandas as pd
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
np.set_printoptions(threshold=np.inf)#输出全部显示
np.set_printoptions(linewidth=10000)
u=1
#f1=open(r'D:/LY/lieb/onelatticedos.txt','w+')
width=int(5)#2D lieb21 lattices width
length=int(5)#2D lieb21 lattices length
w1=int((length+1)/2)
w2=int((width+1)/2)
l1=int((length-1)/2)


while (u<2):      #avg

    h = np.zeros((width*w1+w2*l1,width*w1+w2*l1))  # lieb lattices hamiltonian
    # onesite
    for x in range(width*w1+w2*l1):
        for y in range(width*w1+w2*l1):
            if (x == y):
                s =0#random.uniform(-0.4,0.4)  onesite torm
                h[x, y] = s
    # hopping in  y direction
    for x in range(1, width+1):
        for y in range(1, length):
            if np.mod(x * 3, 2) == 1:
                if np.mod(y * 3, 2) == 1:
                    y11=int((width+1)/2+width)
                    y12=int((y-1)/2)
                    y13=int((x+1)/2+width)
                    y1=int(y11*y12+x)
                    y2=int(y1-x+y13)
                    diag1=random.uniform(-3,5)
                    h[y1-1,y2-1] = diag1
                    h[y2-1,y1-1] = diag1
                if np.mod(y, 2) == 0:
                    y31=int((y/2)*width+(x+1)/2)
                    y32=int((width+1)/2*(y/2-1))
                    y3=y31+y32
                    y4=int(y3+(width-x)/2+x)
                    diag2 =random.uniform(-3,5)
                    h[y3-1,y4-1] = diag2
                    h[y4-1,y3-1] = diag2
    # hopping in  x direction
    for y in range(1,length+1):
        for x in range(1,width):
            if np.mod(y * 3, 2) == 1:
                x11=int((width+1)/2+width)
                x12=int((y-1)/2)
                x1=int(x11*x12+x)
                x2=int(x11*x12+x+1)
                diag3=random.uniform(-3,5)
                h[x1-1,x2-1] = diag3
                h[x2-1,x1-1] = diag3

    print(h)
    eigenvalue,featurevector=np.linalg.eig(h)  # Calculate eigenvalues and eigenvectors
    mid_np = np.array(eigenvalue)
    # 列表转数组
    mid_np_2f = np.round(mid_np, 5)
    # 对数组中的元素保留5位小数
    list_new = list(mid_np_2f)
    # 数组转列表
# 将list转为dataframe显然就变成一-列了
    d = pd.DataFrame(list_new)
    d.to_csv('C:/Users/ASUS/Desktop/1.csv', index=False, mode='a', header=None)  # mode表示追加在追加
# 写入1.csv文件夹
    u=u+1




# Boat DEMO

The first experiment of the semester in software engineering -- some service suppose to manage boat dock

## Project Background

> There is a boat dock in a park. The owner wants to develop a boat management system. The requireemnts are: When toursts rent boats, the adminstator imputs S to start the rent circle; when the toursts return boats, the admin inputs E to end the circle. When a day is over, we need to print the renting number and the average renting time.

This is the original requirements and teacher give the **Algorithm** ( pseudo code ) in class, like this:

```C
Number = Total_time = 0;
GetMessage;
While(!End_of_stream){
  if(Code == S){
    Number++;
    Total_time -= Start_time;
  }
  else 
    Total_time += End_time;
  GetMessage;
  }
Print Number;
If (Number > 0) Average_time = Total_time/Number
}
```

Then he came up with some new requirements, like this:

> 1. Output thelongest renting time in a day.
> 2. Output based on the morning and afternoon.
> 3. When the communication has problems, the incomplete renting messages can he deleted.

### This Pic

![IMG_1661](https://pic.freanja.cn/images/2021/10/12/202110130229803.jpg)

![截屏2021-10-13 上午2.36.22](https://pic.freanja.cn/images/2021/10/12/202110130236856.png)





## My Plan

Because teacher required we to give a gui interface, I'm not familiar with javafx and c# ( although we learn them last semester😅 ), so I choose swift to project a ios application ( and i regret soon... )



## 10.10 Schedule

In fact , during the National Day holiday, I roughly completed the requirements, like 

1. The return of the boat and the loaned animation. ( UI drawing and adaptation took a lot op work, but it didn't  make sense, and that's when I realized *use swift* wasn't a good chioce, this is just a classroom experiment🦉 )
2. Realize the data storage. This can be easily implemented using Userdefaults, and data can keep when next time open this app, I think it's important in actual use.

Emm, probably these features, but it took me a lot of time, I also reviewed and learned many about swift development :smile:

After returning to school, I continued to complete the layout and display of the infomation display to admins interface. This was handy because the data storage was done.

 I relearned the layout of the controls, which I wasn't really familiar with, and I usually chose to program directly in a '.swift' file, but I know this is not the right way to study, so I am gradually learning.



## 10.12 Schedule

Today we took a presentation, and the students used various ways to implement it. I learned a lot and came up with many ways to improve my project. At the same time, I realized that I had misunderstood requirement 3, so i have to continue update this project , also i already tired this project...

This time i maybe migrate this ios applicatition to macos application, because i think mobie screen isn’t fit to show all infomation and maybe application in pc is more convenient  for admins? maybe


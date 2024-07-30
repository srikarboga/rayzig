# Ray tracing in one weekend in zig

Reference: <https://raytracing.github.io/books/RayTracingInOneWeekend.html>

Zig version: 0.13.0

## To use this project

``` 
git clone https://github.com/srikarboga/rayzig.git
cd rayzig
zig run main.zig > out.ppm
```

It takes about 10 mins to render with a ryzen 5900x cpu with the default settings which can be changed in `camera.zig` . After which you can view the image in a ppm viewer of your choice. If you have the kitty terminal you can use `kitten icat out.ppm` to view it.

---
![image](https://github.com/user-attachments/assets/4b96989c-d170-4865-9e91-732fc2147d6d)

---
The code for this project could use a lot of improvements as it was my first project in this language. Goals for the future are to refactor and clean up the code and add multithreading.

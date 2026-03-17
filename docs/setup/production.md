# Môi trường Production

## Cách 1: Cần cài đặt lại từ đầu (Nếu đã cái các service khác vào máy)

### Bước 1: Clone thư mục root về máy

```bash
git clone --recurse-submodules https://github.com/stardust-zip/hpc_root.git
cd hpc_root 
chmod +x local_deploy.sh # Cấp quyền chạy script 
./local_deploy # Chay script
```

Nếu xảy ra lỗi database trong quá trình chạy script, chạy lệnh:

```bash
./local_deploy --fresh
```

### Bước 2: Code trong service của mình

VD: Thêm một file temp.md vào LMS.

```bash
cd LMS # Di chuyển tới LMS
git switch main # Hoặc là master, tùy vào tên nhánh chính
touch temp.md # Tạo file mẫu với tên temp.md
git add temp.md
git commit -m # "test: add temp file"
git push origin main # Hoặc push lên nhánh tùy vào cấu trúc service của mình
git pull # Nhớ cập nhật code mới nhất
```

### Bước 3: Đẩy code lên server

```bash
cd .. # Di chuyển tới hpc_root
git add LMS # Chú ý: Chỉ thêm service của mình!
git commit -m "feat: update LMS"
git push origin main # Hệ thống sẽ tự động build và đẩy lên server tại bước này.
```

## Cách 2: Không cần cài lại

### Bước 1: Clone thư mục root về máy

```bash
git clone --recurse-submodules https://github.com/stardust-zip/hpc_root.git
cd hpc_root 
```

### Bước 2: Code trong service của mình
VD:, sau khi clone `hpc_root`, ta có cấu trúc sau

```bash
hpc_root LMS
```

> [!warning]
> Không code trong hpc_root/LMS, chỉ code trong LMS nếu thực hiện cách 2.

```bash
cd LMS
touch temp.md # Tạo file mẫu với tên temp.md
git add temp.md
git commit -m # "test: add temp file"
git push origin main # Hoặc push lên nhánh tùy vào cấu trúc service của mình
git pull # Nhớ cập nhật code mới nhất
```

### Bước 3: Cập nhật LMS trong `hpc_root`

```bash
cd ../hpc_root/LMS # Truy cập service của bạn trong hpc_root, tuyd đường dẫn
git switch main # hoặc master
git fetch origin main
git pull
```


### Bước 4: Đẩy code lên server

```bash
cd .. # Di chuyển tới hpc_root
git add LMS # Chú ý: Chỉ thêm service của mình!
git commit -m "feat: update LMS"
git push origin main # Hệ thống sẽ tự động build và đẩy lên server tại bước này.
```

# README

## Giới thiệu
- **System-Management:** Văn Anh, Đức Anh
- **Module-TuyenDung:** Nam
- **LMS:** Lâm 
- **hpc_drive:** Độ
- **hpc_dispatch_management:** Hiếu

## Cài đặt
### Clone về máy 
```bash
git clone --recurse-submodules https://github.com/nguyenhieu/hpc_root.git

cd hpc_root
```
- Sau khi clone thì tất cả các microservice sẽ có trong thư mục hpc_root.

### Chạy Docker
#### Nếu chạy lần đầu trên máy
```bash
docker compose up -d --build
```
#### Nếu đã chạy từ trước trên máy 
```bash
docker compose up -d
```

### Quy trình làm việc hàng ngày
#### Cập nhật code (Pull)
```bash
git pull --recurse-submodules
```

#### Phát triển tính năng
- **VD:** Cần sửa code trong System-Management
1. **Đi vào service và Checkout nhánh:**
```bash
cd System-Management
git checkout main # hoặc nhánh mà nhóm dùng idk 
git pull origin main
```

2. **Code, Commit and Push (Trong microservice của mình):**
```bash
# Code xong
git add . 
git commit -m "viet j do"
git push origin main
```

3. **Cập nhật Root Repo:**
```bash
cd .. # quay ra hpc_root
git status
git add System-Management
git commit -m "Update System-Management to latest version"
git push origin main
```




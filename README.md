# README

## Clone về máy 
```bash
git clone --recurse-submodules https://github.com/nguyenhieu/hpc_root.git

cd hpc_root
```
- Sau khi clone thì tất cả các microservice sẽ có trong thư mục `hpc_root`.

## Chạy script cài đặt
### Cấp quyền
```bash
chmod +x setup.sh 
```
### Cài đặt
```bash
./setup.sh
```
- Sau khi cài đặt, sẽ có các microservices + fe và tài khoản để truy cập.

### Lỗi khi cài đặt
- Nếu xảy ra lỗi liên quan đến `staff_count` khi cài đặt, thực hiện các bước sau:
1. **Truy cập `System-Management`:**
```bash
cd System-Management
```
2. **Chỉnh file `database/seeders/AdminSeeder.php`:**
```php
class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Chạy seeder cho mẫu thông báo
        $this->call(NotificationTemplateSeeder::class);

        // Kiểm tra và tạo đơn vị mẫu (unit)
        $unit = DB::table('department')->where('name', 'Khoa Công nghệ Thông tin')->first();
        if (!$unit) {
            $unitId = DB::table('department')->insertGetId([
                'name' => 'Khoa Công nghệ Thông tin',
                'type' => 'faculty',
                'parent_id' => null,
                'staff_count' => 0 <-- Thêm staff_count
            ]);
        } else {
            $unitId = $unit->id;
        }
```

3. **Xóa các volume hỏng:**
```bash
# Tại hpc_root
docker compose down -v
```

4. **Cài đặt lại:**
```bash
./setup.sh
```

## Quy trình làm việc hàng ngày
### Cập nhật code (`pull`)
```bash
git pull --recurse-submodules
```

### Phát triển tính năng
- **VD:** Cần sửa code trong System-Management
1. **Đi vào service và `checkout` nhánh:**
```bash
cd System-Management
git checkout main # hoặc nhánh mà nhóm dùng idk 
git pull origin main
```

2. **Code, `commit` and `push` (Trong microservice của mình):**
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




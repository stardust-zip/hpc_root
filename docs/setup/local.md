# Môi trường Local

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



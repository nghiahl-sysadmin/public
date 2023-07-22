#### Các sử dụng Vagrant
- Lệnh khởi tạo một tệp cấu hình mới cho môi trường ảo "Vagrantfile" tệp chứa cấu hình mà Vagrant sử dụng để tạo và quản lý các máy ảo
```
vagrant init
```
- Lệnh kiểm tra cú pháp và xác thực cấu hình của tệp Vagrantfile
```
vagrant validate
```
- Lệnh áp dụng cấu hình Vagrantfile để tạo máy ảo
```
vagrant up
```
- Lệnh xem danh sách máy ảo đang tồn tại
```
vagrant status
```
- Lệnh xoá máy ảo
```
vagrant destroy -force
```
- Lệnh lưu snapshot cho các máy ảo
```
vagrant snapshot save example
```
- Lệnh xem danh sách snapshot
```
vagrant snapshot list
```
- Lệnh restore snapshot
```
vagrant snapshot restore example
```

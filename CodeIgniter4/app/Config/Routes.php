<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */

// ============================================================
// ROUTE PUBLIK (tidak perlu login)
// ============================================================

// Landing page → katalog publik
$routes->get('/', '\App\Controllers\Web\DashboardController::index');
$routes->get('katalog', '\App\Controllers\Web\DashboardController::index');

// Grup Autentikasi (publik)
$routes->group('', ['namespace' => 'App\Controllers\Web'], function($routes) {
    $routes->get('login', 'AuthController::index');
    $routes->post('login/auth', 'AuthController::login');
    $routes->get('register', 'AuthController::register');
    $routes->post('register/store', 'AuthController::storeRegister');
    $routes->get('logout', 'AuthController::logout');
});

// ============================================================
// ROUTE ADMIN (wajib login — dilindungi oleh AuthFilter)
// Role-based access control via RoleFilter
// ============================================================

$routes->group('admin', ['namespace' => 'App\Controllers\Web', 'filter' => 'auth'], function($routes) {
    // Dashboard (ADMIN + KARYAWAN)
    $routes->get('dashboard', 'AdminController::index');
    
    // Transaksi (ADMIN + KARYAWAN — kasir dapat membuat transaksi)
    $routes->get('transaksi', 'AdminController::transaksi');
    $routes->post('transaksi/simpan', 'AdminController::simpanTransaksi');
    
    // Riwayat Transaksi (ADMIN + KARYAWAN — karyawan hanya lihat miliknya)
    $routes->get('riwayat', 'RiwayatController::index');
    $routes->get('riwayat/detail/(:num)', 'RiwayatController::detail/$1');
});

// ============================================================
// ROUTE ADMIN-ONLY (hanya ADMIN yang boleh akses)
// ============================================================

$routes->group('admin', ['namespace' => 'App\Controllers\Web', 'filter' => 'role:admin'], function($routes) {
    // Menu CRUD (ADMIN only)
    $routes->get('menu', 'MenuController::index');
    $routes->post('menu/simpan', 'MenuController::simpan');
    $routes->post('menu/update/(:num)', 'MenuController::update/$1');
    $routes->get('menu/hapus/(:num)', 'MenuController::hapus/$1');
    
    // Kategori CRUD (ADMIN only)
    $routes->post('kategori/simpan', 'KategoriController::simpan');
    $routes->post('kategori/update/(:num)', 'KategoriController::update/$1');
    $routes->get('kategori/hapus/(:num)', 'KategoriController::hapus/$1');
    
    // Hapus Transaksi (ADMIN only)
    $routes->get('riwayat/hapus/(:num)', 'RiwayatController::hapus/$1');
    
    // Karyawan CRUD (ADMIN only)
    $routes->get('karyawan', 'KaryawanController::index');
    $routes->post('karyawan/simpan', 'KaryawanController::simpan');
    $routes->post('karyawan/update/(:num)', 'KaryawanController::update/$1');
    $routes->get('karyawan/hapus/(:num)', 'KaryawanController::hapus/$1');

    // Pendapatan Bulanan (ADMIN only)
    $routes->get('pendapatan', 'PendapatanController::index');
});


// ============================================================
// REST API ROUTES (JSON) - aligned with Spring Boot/Flutter contract
// ============================================================
$routes->group('api', ['namespace' => 'App\Controllers\Api'], function($routes) {
    $routes->get('auth/health', 'AuthController::health');
    $routes->post('auth/register', 'AuthController::register');
    $routes->post('auth/login', 'AuthController::login');

    $routes->get('menu/kategori/(:num)', 'MenuController::findByKategori/$1');
    $routes->post('menu/bulk', 'MenuController::createBulk');
    $routes->delete('menu/bulk', 'MenuController::deleteBulk');
    $routes->resource('menu', ['controller' => 'MenuController']);

    $routes->resource('kategori', ['controller' => 'KategoriController']);

    $routes->post('karyawan/bulk', 'KaryawanController::createBulk');
    $routes->delete('karyawan/bulk', 'KaryawanController::deleteBulk');
    $routes->resource('karyawan', ['controller' => 'KaryawanController']);

    $routes->get('transaksi/my', 'TransaksiController::my');
    $routes->get('transaksi/(:num)/detail', 'TransaksiController::detail/$1');
    $routes->resource('transaksi', ['controller' => 'TransaksiController']);
});

// Grup Dashboard (wajib login — dilindungi oleh AuthFilter)
$routes->group('dashboard', ['namespace' => 'App\Controllers\Web', 'filter' => 'auth'], function($routes) {
    $routes->get('/', 'AdminController::index');
});
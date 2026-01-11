<?php

namespace App\Http\Controllers\Api;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

/**
 * @OA\Info(
 *     title="Tuition Management System API",
 *     version="1.0.0",
 *     description="RESTful API for managing tuition institutes, students, teachers, classes, payments, and attendance",
 *     @OA\Contact(
 *         email="support@tuitionmanagement.com"
 *     )
 * )
 *
 * @OA\Server(
 *     url=L5_SWAGGER_CONST_HOST,
 *     description="API Server"
 * )
 *
 * @OA\SecurityScheme(
 *     securityScheme="sanctum",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     description="Enter your Laravel Sanctum token"
 * )
 *
 * @OA\Tag(
 *     name="Authentication",
 *     description="User authentication endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Students",
 *     description="Student management endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Teachers",
 *     description="Teacher management endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Classes",
 *     description="Class management and enrollment endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Payments",
 *     description="Payment management endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Attendance",
 *     description="Attendance tracking endpoints"
 * )
 *
 * @OA\Tag(
 *     name="Dashboard",
 *     description="Dashboard statistics and summaries"
 * )
 *
 * @OA\Tag(
 *     name="RFID",
 *     description="RFID card and gate access endpoints"
 * )
 */
class Controller extends BaseController
{
    use AuthorizesRequests;
    use ValidatesRequests;
}

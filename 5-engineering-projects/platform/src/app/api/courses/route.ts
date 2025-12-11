import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

export async function GET() {
  try {
    const courses = await prisma.course.findMany({
      include: {
        track: true,
        _count: {
          select: { resources: true, tasks: true },
        },
      },
      orderBy: { updatedAt: "desc" },
    });
    return NextResponse.json(courses);
  } catch (error) {
    return NextResponse.json({ error: "Failed to fetch courses" }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { title, code, trackId } = body;

    const course = await prisma.course.create({
      data: {
        title,
        code,
        trackId,
        status: "NOT_STARTED",
      },
    });

    return NextResponse.json(course);
  } catch (error) {
    return NextResponse.json({ error: "Failed to create course" }, { status: 500 });
  }
}


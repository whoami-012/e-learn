import { BookOpen, Users, Clock } from 'lucide-react';

const courses = [
  {
    id: 1,
    icon: BookOpen,
    title: 'Web Development Masterclass',
    students: 1234,
    duration: '6 weeks',
    bgColor: 'from-purple-100 to-purple-200',
    iconColor: 'from-purple-400 to-purple-500',
    shadowColor: 'shadow-purple-200/50',
  },
  {
    id: 2,
    title: 'React & TypeScript Guide',
    icon: BookOpen,
    students: 856,
    duration: '4 weeks',
    bgColor: 'from-blue-100 to-blue-200',
    iconColor: 'from-blue-400 to-blue-500',
    shadowColor: 'shadow-blue-200/50',
  },
  {
    id: 3,
    title: 'Advanced CSS Techniques',
    icon: BookOpen,
    students: 432,
    duration: '3 weeks',
    bgColor: 'from-green-100 to-green-200',
    iconColor: 'from-green-400 to-green-500',
    shadowColor: 'shadow-green-200/50',
  },
  {
    id: 4,
    title: 'JavaScript Fundamentals',
    icon: BookOpen,
    students: 2145,
    duration: '8 weeks',
    bgColor: 'from-amber-100 to-amber-200',
    iconColor: 'from-amber-400 to-amber-500',
    shadowColor: 'shadow-amber-200/50',
  },
];

export function YourCourses() {
  return (
    <div className="mb-6 px-6">
      <div className="space-y-3">
        {courses.map((course) => {
          const Icon = course.icon;
          return (
            <div
              key={course.id}
              className={`bg-gradient-to-br ${course.bgColor} rounded-[22px] p-4 shadow-md ${course.shadowColor} border border-white/50 hover:shadow-lg active:scale-[0.99] transition-all duration-200`}
            >
              <div className="flex items-start gap-3">
                <div className={`w-12 h-12 bg-gradient-to-br ${course.iconColor} rounded-[16px] flex items-center justify-center shadow-md ${course.shadowColor} flex-shrink-0`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-gray-900 mb-2">
                    {course.title}
                  </h3>
                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-1.5">
                      <Users className="w-3.5 h-3.5 text-gray-600" />
                      <span className="text-sm text-gray-700 font-medium">{course.students.toLocaleString()}</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Clock className="w-3.5 h-3.5 text-gray-600" />
                      <span className="text-sm text-gray-700">{course.duration}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

import { Code, Shield, Palette, Briefcase, Brain, TrendingUp, Database, Camera } from 'lucide-react';

const categories = [
  {
    id: 1,
    icon: Code,
    title: 'Development',
    courses: 120,
    gradient: 'from-blue-500 to-blue-600',
    bgColor: 'bg-blue-50',
    shadowColor: 'shadow-blue-500/15',
  },
  {
    id: 2,
    icon: Shield,
    title: 'Cybersecurity',
    courses: 85,
    gradient: 'from-red-500 to-red-600',
    bgColor: 'bg-red-50',
    shadowColor: 'shadow-red-500/15',
  },
  {
    id: 3,
    icon: Palette,
    title: 'Design',
    courses: 95,
    gradient: 'from-purple-500 to-purple-600',
    bgColor: 'bg-purple-50',
    shadowColor: 'shadow-purple-500/15',
  },
  {
    id: 4,
    icon: Briefcase,
    title: 'Business',
    courses: 110,
    gradient: 'from-orange-500 to-orange-600',
    bgColor: 'bg-orange-50',
    shadowColor: 'shadow-orange-500/15',
  },
  {
    id: 5,
    icon: Brain,
    title: 'Data Science',
    courses: 75,
    gradient: 'from-teal-500 to-teal-600',
    bgColor: 'bg-teal-50',
    shadowColor: 'shadow-teal-500/15',
  },
  {
    id: 6,
    icon: TrendingUp,
    title: 'Marketing',
    courses: 68,
    gradient: 'from-pink-500 to-pink-600',
    bgColor: 'bg-pink-50',
    shadowColor: 'shadow-pink-500/15',
  },
  {
    id: 7,
    icon: Database,
    title: 'Database',
    courses: 52,
    gradient: 'from-indigo-500 to-indigo-600',
    bgColor: 'bg-indigo-50',
    shadowColor: 'shadow-indigo-500/15',
  },
  {
    id: 8,
    icon: Camera,
    title: 'Photography',
    courses: 44,
    gradient: 'from-emerald-500 to-emerald-600',
    bgColor: 'bg-emerald-50',
    shadowColor: 'shadow-emerald-500/15',
  },
];

export function BrowseCategories() {
  return (
    <div className="mb-8">
      <div className="px-6 mb-4 flex items-center justify-between">
        <h2 className="font-semibold text-gray-900">Browse Categories</h2>
        <button className="text-blue-600 font-medium hover:text-blue-700 transition-colors duration-200 flex items-center gap-1">
          Explore All
          <span className="text-lg">→</span>
        </button>
      </div>
      <div className="flex gap-3 overflow-x-auto px-6 pb-2 scrollbar-hide">
        {categories.map((category) => {
          const Icon = category.icon;
          return (
            <button
              key={category.id}
              className={`flex-shrink-0 w-[155px] ${category.bgColor} rounded-[18px] p-3.5 shadow-md ${category.shadowColor} border border-white/50 hover:shadow-lg active:scale-[0.97] transition-all duration-200`}
            >
              <div className={`w-11 h-11 bg-gradient-to-br ${category.gradient} rounded-[14px] flex items-center justify-center mb-2.5 shadow-md ${category.shadowColor}`}>
                <Icon className="w-[22px] h-[22px] text-white" />
              </div>
              <h3 className="font-semibold text-gray-900 mb-0.5 text-left">
                {category.title}
              </h3>
              <p className="text-gray-600 text-left">
                {category.courses} Courses
              </p>
            </button>
          );
        })}
      </div>
    </div>
  );
}

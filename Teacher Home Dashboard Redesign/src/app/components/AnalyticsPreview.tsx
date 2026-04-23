import { Users, BookOpen, DollarSign, TrendingUp, ArrowUp } from 'lucide-react';

const stats = [
  {
    id: 1,
    icon: Users,
    label: 'Total Students',
    value: '2,548',
    change: '+12%',
    gradient: 'from-blue-500 to-blue-600',
    bgColor: 'bg-blue-50',
    shadowColor: 'shadow-blue-500/10',
  },
  {
    id: 2,
    icon: BookOpen,
    label: 'Active Courses',
    value: '12',
    change: '+2',
    gradient: 'from-purple-500 to-purple-600',
    bgColor: 'bg-purple-50',
    shadowColor: 'shadow-purple-500/10',
  },
  {
    id: 3,
    icon: DollarSign,
    label: 'Revenue',
    value: '$8,240',
    change: '+18%',
    gradient: 'from-emerald-500 to-emerald-600',
    bgColor: 'bg-emerald-50',
    shadowColor: 'shadow-emerald-500/10',
  },
  {
    id: 4,
    icon: TrendingUp,
    label: 'Engagement',
    value: '94%',
    change: '+5%',
    gradient: 'from-orange-500 to-orange-600',
    bgColor: 'bg-orange-50',
    shadowColor: 'shadow-orange-500/10',
  },
];

export function AnalyticsPreview() {
  return (
    <div className="px-6 mb-8">
      <h2 className="font-semibold text-gray-900 mb-4">Analytics</h2>
      <div className="grid grid-cols-2 gap-3">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div
              key={stat.id}
              className={`${stat.bgColor} rounded-[18px] p-4 shadow-md ${stat.shadowColor} border border-white/50 hover:shadow-lg transition-all duration-200`}
            >
              <div className={`w-10 h-10 bg-gradient-to-br ${stat.gradient} rounded-[13px] flex items-center justify-center mb-3 shadow-md ${stat.shadowColor}`}>
                <Icon className="w-5 h-5 text-white" />
              </div>
              <p className="text-gray-600 mb-1.5">{stat.label}</p>
              <div className="flex items-end justify-between">
                <span className="font-bold text-gray-900">
                  {stat.value}
                </span>
                <div className="flex items-center gap-0.5 px-2 py-0.5 bg-emerald-100 rounded-full">
                  <ArrowUp className="w-3 h-3 text-emerald-600" />
                  <span className="text-xs font-semibold text-emerald-700">
                    {stat.change}
                  </span>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

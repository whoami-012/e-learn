import { Plus, Upload, Calendar } from 'lucide-react';

const actions = [
  {
    id: 1,
    icon: Plus,
    label: 'Create Course',
    description: 'Start a new learning journey',
    gradient: 'from-emerald-500 to-teal-600',
    shadowColor: 'shadow-emerald-500/25',
    isPrimary: true,
  },
  {
    id: 2,
    icon: Upload,
    label: 'Upload Content',
    description: 'Add materials and resources',
    gradient: 'from-violet-500 to-purple-600',
    shadowColor: 'shadow-violet-500/20',
    isPrimary: false,
  },
  {
    id: 3,
    icon: Calendar,
    label: 'Schedule Class',
    description: 'Plan your live sessions',
    gradient: 'from-orange-500 to-pink-600',
    shadowColor: 'shadow-orange-500/20',
    isPrimary: false,
  },
];

export function QuickActions() {
  return (
    <div className="px-6 mb-8">
      <div className="grid grid-cols-1 gap-3">
        {actions.map((action) => {
          const Icon = action.icon;
          return (
            <button
              key={action.id}
              className={`bg-gradient-to-r ${action.gradient} rounded-[20px] ${
                action.isPrimary ? 'p-5' : 'p-4'
              } flex items-center gap-4 shadow-lg ${action.shadowColor} hover:shadow-xl hover:${action.shadowColor} active:scale-[0.98] transition-all duration-200`}
            >
              <div className={`${
                action.isPrimary ? 'w-14 h-14' : 'w-12 h-12'
              } bg-white/20 backdrop-blur-md rounded-[16px] flex items-center justify-center border border-white/30 shadow-inner`}>
                <Icon className={`${action.isPrimary ? 'w-7 h-7' : 'w-[22px] h-[22px]'} text-white`} />
              </div>
              <div className="flex-1 text-left">
                <div className="text-white font-semibold mb-0.5">
                  {action.label}
                </div>
                <div className="text-white/80 text-sm">
                  {action.description}
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

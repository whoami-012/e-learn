import { Play, Clock, TrendingUp } from 'lucide-react';

export function FeaturedActionCard() {
  return (
    <div className="px-6 mb-6">
      <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-[24px] p-5 shadow-md shadow-purple-100/50 border border-purple-100/50 relative overflow-hidden">
        <div className="relative z-10">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-purple-600 text-sm font-medium mb-1">Today's Task</p>
              <h3 className="text-gray-900 font-bold text-lg mb-3">Advanced React Patterns</h3>
              <div className="flex items-center gap-4 mb-3">
                <div className="flex items-center gap-1.5">
                  <div className="w-6 h-6 bg-purple-100 rounded-full flex items-center justify-center">
                    <span className="text-xs text-purple-600 font-semibold">12</span>
                  </div>
                  <span className="text-sm text-gray-600">lessons</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Clock className="w-4 h-4 text-gray-400" />
                  <span className="text-sm text-gray-600">45 min</span>
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-500">Progress</span>
                  <span className="text-xs text-purple-600 font-semibold">68%</span>
                </div>
                <div className="w-full h-1.5 bg-purple-100 rounded-full overflow-hidden">
                  <div className="h-full bg-gradient-to-r from-purple-400 to-pink-400 rounded-full" style={{ width: '68%' }}></div>
                </div>
              </div>
            </div>
            <button className="w-14 h-14 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center shadow-lg shadow-purple-300/40 hover:shadow-xl hover:shadow-purple-300/50 active:scale-95 transition-all duration-200">
              <Play className="w-6 h-6 text-white ml-0.5 fill-white" />
            </button>
          </div>
        </div>
        <div className="absolute bottom-0 right-0 w-32 h-32 bg-gradient-to-br from-purple-200/30 to-pink-200/30 rounded-tl-full"></div>
      </div>
    </div>
  );
}

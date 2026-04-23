import { Bell, Globe, User } from 'lucide-react';

export function TeacherHeader() {
  return (
    <div className="bg-gray-50 px-6 pt-6 pb-5">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 bg-gradient-to-br from-indigo-400 to-purple-400 rounded-full flex items-center justify-center shadow-md shadow-indigo-200/50">
            <User className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-gray-900 font-semibold">
              Hello, Sarah 👋
            </h1>
            <p className="text-gray-500 text-sm">Good Morning</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button
            className="px-3 py-1.5 bg-white rounded-full flex items-center gap-1.5 shadow-sm shadow-black/5 hover:shadow-md transition-all duration-200 active:scale-95 border border-gray-100"
            aria-label="Language"
          >
            <Globe className="w-3.5 h-3.5 text-gray-600" />
            <span className="text-xs text-gray-700 font-medium">EN</span>
          </button>
          <button
            className="relative w-9 h-9 bg-white rounded-full flex items-center justify-center shadow-sm shadow-black/5 hover:shadow-md transition-all duration-200 active:scale-95 border border-gray-100"
            aria-label="Notifications"
          >
            <Bell className="w-4 h-4 text-gray-600" />
            <span className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-red-400 rounded-full border-2 border-gray-50"></span>
          </button>
        </div>
      </div>
    </div>
  );
}

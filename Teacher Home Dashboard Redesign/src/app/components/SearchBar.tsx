import { Search, SlidersHorizontal } from 'lucide-react';

export function SearchBar() {
  return (
    <div className="relative px-6 mb-6">
      <div className="relative group">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-[18px] h-[18px] text-gray-400 group-focus-within:text-indigo-500 transition-colors duration-200" />
        <input
          type="text"
          placeholder="Search courses..."
          className="w-full bg-white rounded-[20px] pl-11 pr-12 py-3.5 shadow-sm shadow-gray-200/50 border border-gray-100 focus:outline-none focus:ring-2 focus:ring-indigo-200 focus:border-indigo-200 focus:shadow-md transition-all duration-200 placeholder:text-gray-400"
        />
        <button
          className="absolute right-3 top-1/2 -translate-y-1/2 w-8 h-8 bg-gray-50 rounded-xl flex items-center justify-center hover:bg-gray-100 transition-colors duration-200 active:scale-95"
          aria-label="Filter"
        >
          <SlidersHorizontal className="w-4 h-4 text-gray-600" />
        </button>
      </div>
    </div>
  );
}

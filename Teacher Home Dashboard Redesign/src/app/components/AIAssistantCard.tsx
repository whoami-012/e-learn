import { Sparkles } from 'lucide-react';

export function AIAssistantCard() {
  return (
    <div className="px-6 mb-6">
      <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-[24px] p-4 shadow-sm shadow-blue-100/50 border border-blue-100/50">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 bg-gradient-to-br from-blue-400 to-indigo-400 rounded-full flex items-center justify-center shadow-md shadow-blue-200/50">
            <Sparkles className="w-5 h-5 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-gray-500 text-sm mb-0.5">Your AI assistant</p>
            <p className="text-gray-900 font-medium">You're teaching great today!</p>
          </div>
          <div className="text-4xl">✨</div>
        </div>
      </div>
    </div>
  );
}

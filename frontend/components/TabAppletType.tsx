import { useGlobal } from "@/components/GlobalContext";

interface TabAppletTypeProps {
  tabs: string[];
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export default function TabAppletType({ tabs, activeTab, onTabChange }: TabAppletTypeProps) {
  const { isTextBigger, isButtonBigger } = useGlobal();

  return (
    <div className="flex space-x-4 mb-6 overflow-x-auto">
      {tabs.map((tab) => (
        <button
          key={tab}
          className={`font-medium transition-colors whitespace-nowrap ${isButtonBigger ? 'px-6 py-4' : 'px-4 py-2'} ${
            isTextBigger ? 'text-base' : 'text-sm'
          } ${activeTab === tab
            ? "text-primary border-b-2 border-primary"
            : "text-muted-foreground hover:text-primary"
          }`}
          onClick={() => onTabChange(tab)}
        >
          {tab}
        </button>
      ))}
    </div>
  );
}

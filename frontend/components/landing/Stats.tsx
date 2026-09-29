import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { Box, Zap, Activity, LucideIcon } from "lucide-react"

interface Stats {
  servicesCount: number;
  actionsCount: number;
  reactionsCount: number;
  appletsCount: number;
}

interface StatCardProps {
  title: string;
  value: number;
  description: string;
  icon: LucideIcon;
}

export default function StatsSection({ stats }: { stats: Stats }) {
  return (
    <section className="py-16 px-8 bg-muted/50">
      <div className="max-w-6xl mx-auto">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          <StatCard title="Services" value={stats.servicesCount} description="Available integrations" icon={Box} />
          <StatCard title="Actions" value={stats.actionsCount} description="Possible triggers" icon={Zap} />
          <StatCard title="Reactions" value={stats.reactionsCount} description="Available responses" icon={Activity} />
          <StatCard title="Templates" value={stats.appletsCount} description="Ready-to-use automations" icon={Box} />
        </div>
      </div>
    </section>
  )
}

function StatCard({ title, value, description, icon: Icon }: StatCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <p className="text-xs text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  )
}
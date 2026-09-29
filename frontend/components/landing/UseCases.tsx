import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { Box, ArrowRight, CheckCircle, LucideIcon } from "lucide-react"

export default function UseCasesSection() {
  return (
    <section className="py-16 px-8 bg-muted/50">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold mb-12 text-center">Popular Use Cases</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <UseCaseCard
            title="Task Automation"
            icon={Box}
            items={[
              "Synchronize tasks across different tools",
              "Automate repetitive workflows"
            ]}
          />
          <UseCaseCard
            title="Data Management"
            icon={ArrowRight}
            items={[
              "Automatically backup your data",
              "Sync data between different services"
            ]}
          />
        </div>
      </div>
    </section>
  )
}

interface UseCaseCardProps {
  title: string;
  icon: LucideIcon;
  items: string[];
}

function UseCaseCard({ title, icon: Icon, items }: UseCaseCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Icon className="h-5 w-5" />
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <ul className="space-y-2">
          {items.map((item, index) => (
            <li key={index} className="flex items-center gap-2">
              <CheckCircle className="h-4 w-4 text-green-500" />
              <span>{item}</span>
            </li>
          ))}
        </ul>
      </CardContent>
    </Card>
  )
}
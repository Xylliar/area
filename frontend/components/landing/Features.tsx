import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"

export default function FeaturesSection() {
  return (
    <section className="py-16 px-8">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold mb-12 text-center">Key Features</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <FeatureCard title="Automation" description="Create powerful automated workflows between your favorite services" />
          <FeatureCard title="Integration" description="Connect multiple services seamlessly in one platform" />
          <FeatureCard title="Customization" description="Tailor your automation rules to match your specific needs" />
        </div>
      </div>
    </section>
  )
}

function FeatureCard({ title, description }: { title: string, description: string }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  )
}
export default function HowItWorksSection() {
    return (
      <section className="py-16 px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold mb-12 text-center">How It Works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <Step number={1} title="Choose a Trigger" description="Select an action that will start your automation" />
            <Step number={2} title="Add Reactions" description="Configure what happens when your trigger is activated" />
            <Step number={3} title="Let It Run" description="Your automation works in the background while you focus on what matters" />
          </div>
        </div>
      </section>
    )
  }

  function Step({ number, title, description }: { number: number, title: string, description: string }) {
    return (
      <div className="flex flex-col items-center text-center">
        <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center mb-4">
          <span className="text-2xl font-bold text-primary">{number}</span>
        </div>
        <h3 className="text-xl font-semibold mb-2">{title}</h3>
        <p className="text-muted-foreground">{description}</p>
      </div>
    )
  }
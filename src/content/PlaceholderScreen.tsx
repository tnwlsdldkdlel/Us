import type { ReactElement } from 'react';
import { Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { contentStyles } from './styles';

type PlaceholderScreenProps = {
  title: string;
};

export default function PlaceholderScreen({
  title,
}: PlaceholderScreenProps): ReactElement {
  return (
    <SafeAreaView edges={["left", "right", "bottom"]} style={contentStyles.safeArea}>
      <View style={contentStyles.container}>
        <Text style={contentStyles.screenHeading}>{title}</Text>
        <Text style={contentStyles.screenBody}>콘텐츠를 구성하세요.</Text>
      </View>
    </SafeAreaView>
  );
}
